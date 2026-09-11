import React, { forwardRef } from 'react';
import { Form } from 'formik';
import { Link } from 'react-router-dom';
import styled from 'styled-components/macro';
import tw from 'twin.macro';
import FlashMessageRender from '@/components/FlashMessageRender';
import Snowfall from '@/components/auth/Snowfall';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faHome } from '@fortawesome/free-solid-svg-icons';

type Props = React.DetailedHTMLProps<React.FormHTMLAttributes<HTMLFormElement>, HTMLFormElement> & {
    title?: string;
};

const LoginPage = styled.div`
    ${tw`relative min-h-screen w-full flex items-center justify-center overflow-hidden px-4 py-8`};
    background-color: #0f172a;
    background-image: url('/assets/thunderbyte/background.png');
    background-size: cover;
    background-position: center;
    font-family: 'Inter', sans-serif;
`;

const Overlay = styled.div`
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.7);
    z-index: 0;
`;

const Breadcrumb = styled.div`
    ${tw`absolute top-5 left-5 z-10 flex items-center gap-2 rounded-full px-4 py-2 text-sm shadow-lg whitespace-nowrap`};
    background: rgba(15, 23, 42, 0.7);
    border: 1px solid rgba(59, 130, 246, 0.3);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
`;

const Card = styled.div`
    ${tw`relative z-10 w-full max-w-[420px] px-7 py-10 sm:px-9`};
    background: rgba(15, 23, 42, 0.9);
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 12px;
    box-shadow: 0 20px 45px rgba(0, 0, 0, 0.55);
    backdrop-filter: blur(16px) saturate(160%);
    -webkit-backdrop-filter: blur(16px) saturate(160%);
`;

const Footer = styled.footer`
    ${tw`absolute bottom-4 left-0 w-full text-center z-10 text-xs px-4`};
    color: rgba(255, 255, 255, 0.6);
`;

export default forwardRef<HTMLFormElement, Props>(({ title, ...props }, ref) => {
    // Login "title" is intentionally ignored — the ThunderByte theme renders its own
    // branded header above the form.
    const year = new Date().getFullYear();

    return (
        <LoginPage>
            <Overlay />
            <Snowfall />
            <Breadcrumb>
                <Link
                    to={'/'}
                    css={tw`flex items-center gap-1.5 font-semibold no-underline transition-colors duration-200`}
                >
                    <FontAwesomeIcon icon={faHome} size={'sm'} />
                    <span css={tw`text-white`}>Home</span>
                </Link>
                <span css={tw`text-white/40`}>/</span>
                <span css={tw`text-blue-500 font-bold`}>Login</span>
            </Breadcrumb>
            <Card>
                <div css={tw`text-center mb-8`}>
                    <img
                        src={'/assets/thunderbyte/logo.png'}
                        alt={'ThunderByte'}
                        css={tw`w-[70px] h-[70px] object-contain rounded-2xl p-2 mb-4 mx-auto`}
                        style={{
                            background: 'rgba(59, 130, 246, 0.12)',
                            border: '1px solid rgba(59, 130, 246, 0.25)',
                        }}
                    />
                    <h2 css={tw`text-[1.8rem] font-extrabold text-white leading-tight`}>Welcome Back</h2>
                    <p css={tw`text-white/70 text-sm mt-1`}>Log in to manage your services</p>
                </div>
                <FlashMessageRender className={'mb-4'} />
                <Form {...props} ref={ref}>
                    {props.children}
                </Form>
            </Card>
            <Footer>
                &copy; {year} <span css={tw`font-bold text-white`}>ThunderByte</span> | Powered by Pterodactyl
            </Footer>
        </LoginPage>
    );
});